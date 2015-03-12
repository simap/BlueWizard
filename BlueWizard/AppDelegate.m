#import "AppDelegate.h"
#import "SpeechSynthesizer.h"
#import "Sampler.h"
#import "Input.h"
#import "Output.h"
#import "TestSampleData.h"
#import "Processor.h"
#import "SpeechDataReader.h"
#import "SpeechSynthesizer.h"
#import "PlayheadView.h"
#import "NotificationNames.h"

@interface AppDelegate ()

@property (nonatomic, strong) SpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) Sampler *sampler;
@property (nonatomic, strong) Input *input;
@property (nonatomic, strong) Processor *processor;
@property (nonatomic, strong) Buffer *buffer;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playOriginalWasClicked:) name:playOriginalWasClicked object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopWasClicked:) name:stopOriginalWasClicked object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcessedWasClicked:) name:playProcessedWasClicked object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopWasClicked:) name:stopProcessedWasClicked object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bufferGenerated:) name:bufferGenerated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processInputSignalWasClicked:) name:processInputSignalWasClicked object:nil];

    
//    NSArray *speechData = [SpeechDataReader speechDataFromFile:@"test"];
//    Buffer *buffer = [SpeechSynthesizer processSpeechData:speechData];
//    [self.sampler stream:buffer];
//    [self openFileBrowser];
//    
//    NSMutableArray *samples = [NSMutableArray array];
//    for (NSNumber *num in [TestSampleData samples]) {
//        float f = ((float)[num intValue]) / (1 << 15);
//        [samples addObject:[NSNumber numberWithFloat:f]];
//    }
//    [Output save:samples];
//    [self.sampler stream:[i samples] sampleRate:48000];
//    [self openFileBrowser];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.sampler stop];
}

-(Sampler *)sampler {
    if (!_sampler) {
        _sampler = [[Sampler alloc] initWithDelegate:self];
    }
    return _sampler;
}

# pragma mark - MenuItems

- (IBAction)MenuFileOpenWasChosen:(id)sender {
    NSOpenPanel* dialog = [NSOpenPanel openPanel];
    [dialog setCanChooseFiles:YES];
    [dialog setCanChooseDirectories:YES];
    
    if ([dialog runModal] == NSModalResponseOK) {
        for (NSURL* URL in [dialog URLs]) {
            self.input = [[Input alloc] initWithURL:URL];
            [[NSNotificationCenter defaultCenter] postNotificationName:inputSignalReceived object:self.input.buffer];
        }
    }
}

-(void)playOriginalWasClicked:(NSNotification *)notification {
//    ((PlayheadView *)notification.object).sampler = self.sampler;
    [self.sampler stream:[self.input buffer]];
}

-(void)playProcessedWasClicked:(NSNotification *)notification {
//    ((PlayheadView *)notification.object).sampler = self.sampler;
    [self.sampler stream:self.buffer];
}

-(void)processInputSignalWasClicked:(NSNotification *)notification {
    //    ((PlayheadView *)notification.object).sampler = self.sampler;
    self.processor = [Processor process:[self.input buffer]];
}

-(void)stopWasClicked:(NSNotification *)notification {
    [self.sampler stop];
}

-(void)bufferGenerated:(NSNotification *)notification {
    self.buffer = (Buffer *)notification.object;
}

# pragma mark - SamplerDelegate

-(void)didFinishStreaming:(Buffer *)buffer {
}

@end
